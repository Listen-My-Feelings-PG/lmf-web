import { psql } from '../main';
import { queryExec } from '../services/utils.service';

export function getUser(_username: string, cb: (data: any) => void): void {
  queryExec(psql``, cb);
}
