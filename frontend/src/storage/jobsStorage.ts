import { create } from "zustand";
import { persist } from "zustand/middleware";

export interface SubJob {
  id: string;
  title: string;
  volume: number;
  unitOfMeasurement: string;
  startDate: string;
  endDate: string;
}

export interface Job {
  id: string;
  title: string;
  startDate: string;
  endDate: string;
  subJobs: SubJob[];
}

interface JobsState {
  jobs: Job[];
  hydrated: boolean;
  setHydrated: () => void;
  addJob: (job: Job) => void;
  updateJob: (id: string, updated: Partial<Job>) => void;
  deleteJob: (id: string) => void;
  updateSubJob: (jobId: string, subJobId: string, updated: Partial<SubJob>) => void;
}

export const useActionsStore = create<JobsState>()(
    persist(
        (set) => ({
          jobs: [],
          hydrated: false,

          setHydrated: () => set({ hydrated: true }),

          addJob: (job) =>
              set((state) => ({ jobs: [...state.jobs, job] })),

          updateJob: (id, updated) =>
              set((state) => ({
                jobs: state.jobs.map((j) =>
                    j.id === id ? { ...j, ...updated } : j
                ),
              })),

          deleteJob: (id) =>
              set((state) => ({
                jobs: state.jobs.filter((j) => j.id !== id),
              })),

          updateSubJob: (jobId, subJobId, updated) =>
              set((state) => ({
                jobs: state.jobs.map((j) =>
                    j.id === jobId
                        ? {
                          ...j,
                          subJobs: j.subJobs.map((s) =>
                              s.id === subJobId ? { ...s, ...updated } : s
                          ),
                        }
                        : j
                ),
              })),
        }),
        {
          name: "jobs-storage",
          onRehydrateStorage: () => (state) => {
            state?.setHydrated();
          },
        }
    )
);
