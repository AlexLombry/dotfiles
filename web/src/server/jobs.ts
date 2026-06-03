import { spawn } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import type { Response } from 'express';
import type { JobStatus, AnyJobEvent, JobSummary } from '../shared/types';

export interface Job {
  id:          string;
  label:       string;
  status:      JobStatus;
  output:      AnyJobEvent[];
  listeners:   Set<Response>;
  startedAt:   number;
  finishedAt?: number;
  exitCode?:   number;
}

export interface RunProcOptions {
  job:       Job;
  cmd:       string;
  args:      string[];
  cwd:       string;
  extraEnv?: NodeJS.ProcessEnv;
}

const jobs = new Map<string, Job>();

export function createJob(label: string): Job {
  const id  = randomUUID();
  const job: Job = {
    id, label, status: 'running', output: [], listeners: new Set(), startedAt: Date.now(),
  };
  jobs.set(id, job);
  if (jobs.size > 100) {
    const oldest = jobs.keys().next().value;
    if (oldest !== undefined) jobs.delete(oldest);
  }
  return job;
}

export function getJob(id: string): Job | undefined {
  return jobs.get(id);
}

export function jobEmit(job: Job, type: 'stdout' | 'stderr', data: string): void;
export function jobEmit(job: Job, type: 'exit', data: { code: number }): void;
export function jobEmit(job: Job, type: AnyJobEvent['type'], data: AnyJobEvent['data']): void {
  const ev = { type, data, ts: Date.now() } as AnyJobEvent;
  job.output.push(ev);
  for (const res of job.listeners) res.write(`data: ${JSON.stringify(ev)}\n\n`);
}

export function jobFinish(job: Job, code: number): void {
  job.status    = code === 0 ? 'success' : 'failed';
  job.exitCode  = code;
  job.finishedAt = Date.now();
  jobEmit(job, 'exit', { code });
  for (const res of job.listeners) res.end();
  job.listeners.clear();
}

export function runProc({ job, cmd, args, cwd, extraEnv = {} }: RunProcOptions): Promise<number> {
  return new Promise(resolve => {
    const proc = spawn(cmd, args, {
      cwd,
      shell: false,
      env: { ...process.env, ...extraEnv },
    });
    proc.stdout.on('data', (d: Buffer) => jobEmit(job, 'stdout', d.toString()));
    proc.stderr.on('data', (d: Buffer) => jobEmit(job, 'stderr', d.toString()));
    proc.on('close', (code: number | null) => {
      const exitCode = code ?? 1;
      jobFinish(job, exitCode);
      resolve(exitCode);
    });
    proc.on('error', (err: Error) => {
      jobEmit(job, 'stderr', `spawn error: ${err.message}\n`);
      jobFinish(job, 1);
      resolve(1);
    });
  });
}

export function getJobSummary(job: Job): JobSummary {
  const summary: JobSummary = {
    id: job.id, label: job.label, status: job.status, startedAt: job.startedAt,
  };
  if (job.exitCode !== undefined) summary.exitCode = job.exitCode;
  if (job.finishedAt !== undefined) summary.finishedAt = job.finishedAt;
  return summary;
}
