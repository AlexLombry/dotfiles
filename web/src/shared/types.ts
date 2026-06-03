export type FileStatus = 'linked' | 'missing' | 'conflict' | 'broken';
export type JobStatus  = 'running' | 'success' | 'failed';
export type StowMode   = 'stow' | 'dry-run' | 'unstow' | 'adopt';
export type EventType  = 'stdout' | 'stderr' | 'exit';

export interface FileEntry {
  rel:    string;
  src:    string;
  dest:   string;
  status: FileStatus;
}

export interface Package {
  name:   string;
  files:  FileEntry[];
  error?: string;
}

// Discriminated union — exit event carries { code }, stdout/stderr carry a plain string
export interface JobEvent {
  type: 'stdout' | 'stderr';
  data: string;
  ts:   number;
}

export interface ExitEvent {
  type: 'exit';
  data: { code: number };
  ts:   number;
}

export type AnyJobEvent = JobEvent | ExitEvent;

export interface JobSummary {
  id:          string;
  label:       string;
  status:      JobStatus;
  exitCode?:   number;
  startedAt:   number;
  finishedAt?: number;
}

export interface CommandConfig {
  label: string;
  safe:  boolean;
  desc:  string;
}

export interface CommandEntry extends CommandConfig {
  cmd: string;
}

// ── API request / response shapes ────────────────────────────────────────────

export interface InfoResponse {
  dotfilesDir: string;
  stowDir:     string;
  homeDir:     string;
  packages:    string[];
  backupBase:  string;
}

export interface JobIdResponse {
  jobId: string;
}

export interface PrerequisiteResult {
  name:    string;
  ok:      boolean;
  version: string;
}

export interface BackupEntry {
  name:      string;
  fileCount: number;
}

export interface ApiError {
  error: string;
}

export interface StowRequestBody {
  packages?: string[];
  mode?:     StowMode;
}

export interface BackupRequestBody {
  packages?: string[];
}

export interface RunRequestBody {
  command: string;
}
