// Pure Dart QR Code (ISO/IEC 18004) Matrix Generator
// Offline, zero external dependencies.

final class QrMatrixGenerator {
  const QrMatrixGenerator();

  static final List<int> _expTable = List<int>.filled(512, 0);
  static final List<int> _logTable = List<int>.filled(256, 0);
  static bool _tablesInitialized = false;

  static void _initGfTables() {
    if (_tablesInitialized) return;
    var x = 1;
    for (var i = 0; i < 255; i++) {
      _expTable[i] = x;
      _expTable[i + 255] = x;
      _logTable[x] = i;
      x <<= 1;
      if ((x & 0x100) != 0) {
        x ^= 0x11d;
      }
    }
    _tablesInitialized = true;
  }

  static int _gmult(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return _expTable[_logTable[a] + _logTable[b]];
  }

  static List<int> _generateRsPoly(int errorCount) {
    var poly = <int>[1];
    for (var i = 0; i < errorCount; i++) {
      final next = <int>[];
      final factor = _expTable[i];
      next.add(poly[0]);
      for (var j = 1; j < poly.length; j++) {
        next.add(poly[j] ^ _gmult(poly[j - 1], factor));
      }
      next.add(_gmult(poly.last, factor));
      poly = next;
    }
    return poly;
  }

  static List<int> _calculateEcc(List<int> data, int errorCount) {
    final genPoly = _generateRsPoly(errorCount);
    final ecc = List<int>.filled(errorCount, 0);

    for (final b in data) {
      final factor = b ^ ecc[0];
      for (var i = 0; i < errorCount - 1; i++) {
        ecc[i] = ecc[i + 1] ^ _gmult(genPoly[i + 1], factor);
      }
      ecc[errorCount - 1] = _gmult(genPoly[errorCount], factor);
    }
    return ecc;
  }

  // Precomputed alignment pattern coordinates for versions 1 to 14
  static const List<List<int>> _alignmentCoords = [
    [], // v1
    [6, 18], // v2
    [6, 22], // v3
    [6, 26], // v4
    [6, 30], // v5
    [6, 34], // v6
    [6, 22, 38], // v7
    [6, 24, 42], // v8
    [6, 26, 46], // v9
    [6, 28, 50], // v10
    [6, 30, 54], // v11
    [6, 32, 58], // v12
    [6, 34, 62], // v13
    [6, 26, 46, 66], // v14
  ];

  // Capacity in bytes for EC Level L (versions 1 to 14)
  static const List<int> _capacities = [
    17, 32, 53, 78, 106, 134, 154, 192, 230, 271, 321, 367, 425, 458,
  ];

  // Total data codewords for Level L
  static const List<int> _dataCodewords = [
    19, 34, 55, 80, 108, 136, 156, 194, 232, 274, 324, 370, 428, 461,
  ];

  // ECC codewords per block for Level L
  static const List<int> _ecCodewordsPerBlock = [
    7, 10, 15, 20, 26, 18, 20, 24, 30, 18, 20, 24, 26, 30,
  ];

  // Blocks count for Level L
  static const List<int> _blocksCount = [
    1, 1, 1, 1, 1, 2, 2, 2, 2, 4, 4, 4, 4, 3,
  ];

  List<List<bool>> generate(String data) {
    _initGfTables();
    final bytes = data.codeUnits;

    // 1. Pick minimal QR version that fits the payload
    var version = 1;
    while (version <= _capacities.length && bytes.length > _capacities[version - 1]) {
      version++;
    }
    if (version > _capacities.length) {
      version = _capacities.length; // Max supported fallback
    }

    final totalDataBytes = _dataCodewords[version - 1];
    final numBlocks = _blocksCount[version - 1];
    final ecPerBlock = _ecCodewordsPerBlock[version - 1];

    // 2. Build bit buffer: Mode (0100) + Count + Data + Terminator
    final bitBuffer = <int>[];
    void appendBits(int value, int count) {
      for (var i = count - 1; i >= 0; i--) {
        bitBuffer.add((value >> i) & 1);
      }
    }

    // Byte mode = 0100
    appendBits(4, 4);
    // Character count indicator (8 bits for v1-9, 16 bits for v10+)
    appendBits(bytes.length, version < 10 ? 8 : 16);
    // Data bytes
    for (final b in bytes) {
      appendBits(b, 8);
    }
    // Terminator (up to 4 zeroes)
    final capacityBits = totalDataBytes * 8;
    final termLen = (capacityBits - bitBuffer.length).clamp(0, 4);
    appendBits(0, termLen);
    // Pad to multiple of 8
    while (bitBuffer.length % 8 != 0) {
      bitBuffer.add(0);
    }
    // Pad bytes 0xEC and 0x11
    final dataBytes = <int>[];
    for (var i = 0; i < bitBuffer.length; i += 8) {
      var byteVal = 0;
      for (var j = 0; j < 8; j++) {
        byteVal = (byteVal << 1) | bitBuffer[i + j];
      }
      dataBytes.add(byteVal);
    }
    var pad = 0xec;
    while (dataBytes.length < totalDataBytes) {
      dataBytes.add(pad);
      pad = (pad == 0xec) ? 0x11 : 0xec;
    }

    // 3. Divide data into blocks and generate ECC
    final shortBlockLen = totalDataBytes ~/ numBlocks;
    final numLongBlocks = totalDataBytes % numBlocks;
    final numShortBlocks = numBlocks - numLongBlocks;

    final dataBlocks = <List<int>>[];
    final eccBlocks = <List<int>>[];
    var offset = 0;

    for (var i = 0; i < numBlocks; i++) {
      final len = (i < numShortBlocks) ? shortBlockLen : shortBlockLen + 1;
      final blockData = dataBytes.sublist(offset, offset + len);
      offset += len;
      dataBlocks.add(blockData);
      eccBlocks.add(_calculateEcc(blockData, ecPerBlock));
    }

    // 4. Interleave data and ECC codewords
    final finalCodewords = <int>[];
    final maxDataBlockLen = shortBlockLen + (numLongBlocks > 0 ? 1 : 0);
    for (var i = 0; i < maxDataBlockLen; i++) {
      for (var b = 0; b < numBlocks; b++) {
        if (i < dataBlocks[b].length) {
          finalCodewords.add(dataBlocks[b][i]);
        }
      }
    }
    for (var i = 0; i < ecPerBlock; i++) {
      for (var b = 0; b < numBlocks; b++) {
        finalCodewords.add(eccBlocks[b][i]);
      }
    }

    // 5. Construct QR Matrix
    final size = 21 + 4 * (version - 1);
    final matrix = List.generate(size, (_) => List<bool>.filled(size, false));
    final reserved = List.generate(size, (_) => List<bool>.filled(size, false));

    void markFinder(int r, int c) {
      for (var i = -1; i <= 7; i++) {
        for (var j = -1; j <= 7; j++) {
          final row = r + i;
          final col = c + j;
          if (row >= 0 && row < size && col >= 0 && col < size) {
            reserved[row][col] = true;
            if (i >= 0 && i <= 6 && j >= 0 && j <= 6) {
              final isEdge = i == 0 || i == 6 || j == 0 || j == 6;
              final isCenter = i >= 2 && i <= 4 && j >= 2 && j <= 4;
              matrix[row][col] = isEdge || isCenter;
            } else {
              matrix[row][col] = false;
            }
          }
        }
      }
    }

    // Place 3 Finder Patterns
    markFinder(0, 0);
    markFinder(0, size - 7);
    markFinder(size - 7, 0);

    // Timing Patterns
    for (var i = 8; i < size - 8; i++) {
      reserved[6][i] = true;
      matrix[6][i] = i % 2 == 0;
      reserved[i][6] = true;
      matrix[i][6] = i % 2 == 0;
    }

    // Alignment Patterns
    if (version >= 2) {
      final coords = _alignmentCoords[version - 1];
      for (final r in coords) {
        for (final c in coords) {
          if (reserved[r][c]) continue; // Skip if collides with finder
          for (var i = -2; i <= 2; i++) {
            for (var j = -2; j <= 2; j++) {
              reserved[r + i][c + j] = true;
              final isEdge = i.abs() == 2 || j.abs() == 2;
              final isCenter = i == 0 && j == 0;
              matrix[r + i][c + j] = isEdge || isCenter;
            }
          }
        }
      }
    }

    // Reserve Format Information Area
    for (var i = 0; i < 9; i++) {
      reserved[8][i] = true;
      reserved[i][8] = true;
    }
    for (var i = 0; i < 8; i++) {
      reserved[size - 1 - i][8] = true;
      reserved[8][size - 1 - i] = true;
    }
    // Dark module
    matrix[4 * version + 9][8] = true;
    reserved[4 * version + 9][8] = true;

    // Convert final codewords to bits
    final allBits = <int>[];
    for (final cw in finalCodewords) {
      for (var i = 7; i >= 0; i--) {
        allBits.add((cw >> i) & 1);
      }
    }

    // 6. Zigzag data placement
    var bitIndex = 0;
    var upward = true;
    for (var right = size - 1; right > 0; right -= 2) {
      if (right == 6) right--; // Skip vertical timing pattern
      for (var vert = 0; vert < size; vert++) {
        final row = upward ? (size - 1 - vert) : vert;
        for (var col = right; col >= right - 1; col--) {
          if (!reserved[row][col]) {
            var bit = 0;
            if (bitIndex < allBits.length) {
              bit = allBits[bitIndex++];
            }
            // Apply Mask 0: (row + col) % 2 == 0
            final mask = ((row + col) % 2 == 0) ? 1 : 0;
            matrix[row][col] = (bit ^ mask) == 1;
          }
        }
      }
      upward = !upward;
    }

    // 7. Write Format Information (Level L, Mask 0 = 0x77C4 with XOR mask 0x5412 = 0x23D6)
    // 15-bit format sequence for EC Level L (01) and Mask 0 (000):
    const formatBits = [
      true, true, true, false, true, true, true, true, false, false, false, true, false, false, false
    ];
    for (var i = 0; i < 6; i++) {
      matrix[8][i] = formatBits[i];
    }
    matrix[8][7] = formatBits[6];
    matrix[8][8] = formatBits[7];
    matrix[7][8] = formatBits[8];
    for (var i = 9; i < 15; i++) {
      matrix[14 - i][8] = formatBits[i];
    }

    // Second copy of format bits
    for (var i = 0; i < 7; i++) {
      matrix[size - 1 - i][8] = formatBits[i];
    }
    for (var i = 7; i < 15; i++) {
      matrix[8][size - 15 + i] = formatBits[i];
    }

    return matrix;
  }
}
