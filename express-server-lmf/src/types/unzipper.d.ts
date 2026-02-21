declare module 'unzipper' {
  import { Writable } from 'stream';

  interface ExtractOptions {
    path: string;
  }

  export function Extract(options: ExtractOptions): Writable;

  export function Parse(): Writable;
}