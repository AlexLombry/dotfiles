import express from 'express';
import path    from 'node:path';
import { PORT, DOTFILES_DIR } from './config';
import infoRouter        from './routes/info';
import packagesRouter    from './routes/packages';
import commandsRouter    from './routes/commands';
import prereqsRouter     from './routes/prerequisites';
import runRouter         from './routes/run';
import stowRouter        from './routes/stow';
import { backupRouter }  from './routes/backup';
import backupsRouter     from './routes/backups';
import jobsRouter        from './routes/jobs';

export const app = express();

app.use(express.json());
// dist/server/ → go up 2 levels to reach web/, then into public/
app.use(express.static(path.join(__dirname, '..', '..', 'public')));

app.use('/api/info',          infoRouter);
app.use('/api/packages',      packagesRouter);
app.use('/api/commands',      commandsRouter);
app.use('/api/prerequisites', prereqsRouter);
app.use('/api/run',           runRouter);
app.use('/api/stow',          stowRouter);
app.use('/api/backup',        backupRouter);
app.use('/api/backups',       backupsRouter);
app.use('/api/jobs',          jobsRouter);

// Re-export pure functions for the test suite
export { shouldIgnore, isEffectivelyLinked, symlinkStatus, scanPackage } from './fs-utils';

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`\n  Dotfiles Manager  →  http://localhost:${PORT}`);
    console.log(`  Dotfiles root     →  ${DOTFILES_DIR}\n`);
  });
}
