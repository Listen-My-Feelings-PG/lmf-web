import fs from 'fs';
export function getNpyFeaturesByfilePath(filePath: string): { data: Float32Array; shape: number[] } {
  const buffer = fs.readFileSync(filePath);
  // Magic: \x93NUMPY
  if (buffer[0] !== 0x93 || buffer.toString('ascii', 1, 6) !== 'NUMPY')
    throw new Error(`Archivo .npy inválido: ${filePath}`);


  const majorVersion = buffer[6];
  let headerLen: number;
  let dataStart: number;

  if (majorVersion === 1) {
    headerLen = buffer.readUInt16LE(8);
    dataStart = 10 + headerLen;
  } else {
    headerLen = buffer.readUInt32LE(8);
    dataStart = 12 + headerLen;
  }

  const headerStr = buffer.toString('ascii', majorVersion === 1 ? 10 : 12, dataStart);
  // Detectar Fortran order (column-major)
  const isFortran = headerStr.includes("'fortran_order': True");
  // Parsear shape: 'shape': (N, 128,)
  const shapeMatch = headerStr.match(/'shape':\s*\(([^)]+)\)/);
  if (!shapeMatch) throw new Error(`No se puede parsear shape del header .npy: ${filePath}`);
  const shape = shapeMatch[1].split(',').map(s => parseInt(s.trim())).filter(n => !isNaN(n));
  // Parsear dtype
  const dtypeMatch = headerStr.match(/'descr':\s*'([^']+)'/);
  const dtype = dtypeMatch ? dtypeMatch[1] : '<f4';
  // Extraer datos binarios (copia alineada)
  const dataBuffer = buffer.subarray(dataStart);
  const aligned = new ArrayBuffer(dataBuffer.length);
  new Uint8Array(aligned).set(dataBuffer);

  let data: Float32Array;

  if (dtype.includes('f4'))
    data = new Float32Array(aligned);
  else if (dtype.includes('f8'))
    data = Float32Array.from(new Float64Array(aligned));
  else
    throw new Error(`Dtype no soportado: ${dtype}`);

  // Transponer de Fortran order (column-major) a C order (row-major) si es necesario.
  // Fortran almacena los datos columna por columna: el elemento [i,j] está en índice j*rows + i.
  // C order los almacena fila por fila: el elemento [i,j] está en índice i*cols + j.
  // Para shape (rows, cols) hacemos la transposición en memoria.
  if (isFortran && shape.length === 2) {
    const [rows, cols] = shape;
    const transposed = new Float32Array(rows * cols);
    for (let i = 0; i < rows; i++) {
      for (let j = 0; j < cols; j++) {
        transposed[i * cols + j] = data[j * rows + i];
      }
    }
    data = transposed;
  }

  return { data, shape };
}