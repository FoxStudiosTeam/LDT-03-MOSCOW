import { create } from "zustand";

export interface SubJob {
  id: string;
  title: string;
  volume: number;
  unitOfMeasurement: string;
  startDate: string;
  endDate: string;
}

export interface Jobs {
  id: string;
  title: string;
  startDate: string;
  endDate: string;
  SubJobs: SubJob[];
}

interface ActionsState {
  jobs: Jobs[];
  addAction: (action: Jobs) => void;
  updateAction: (id: string, updated: Partial<Jobs>) => void;
  deleteAction: (id: string) => void;
  updateSubActions: (id: string, SubJobs: SubJob[]) => void;
}

export const useActionsStore = create<ActionsState>((set) => ({
  jobs: [],
  addAction: (action) =>
    set((state) => ({ jobs: [...state.jobs, action] })),
  updateAction: (id, updated) =>
    set((state) => ({
      jobs: state.jobs.map((a) =>
        a.id === id ? { ...a, ...updated } : a
      ),
    })),
  deleteAction: (id) =>
    set((state) => ({
      jobs: state.jobs.filter((a) => a.id !== id),
    })),
  updateSubActions: (id, SubJobs) =>
    set((state) => ({
      jobs: state.jobs.map((a) =>
        a.id === id ? { ...a, SubJobs } : a
      ),
    })),
}));
