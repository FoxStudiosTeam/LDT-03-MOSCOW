"use client";
import { create } from "zustand";
import { persist } from "zustand/middleware";

interface Attachment {
    base_entity_uuid: string;
    content_type: string | null;
    original_filename: string;
    uuid: string;
}

interface Project {
    uuid: string;
    address: string;
    created_by: string | null;
    end_date: string | null;
    foreman: string | null;
    polygon: string | null;
    ssk: string | null;
    start_date: string | null;
    status: number;
    customer?: string;
    contractor?: string;
    inspector?: string;
}

export interface ProjectWithAttachments {
    attachments: Attachment[];
    project: Project;
}

interface ProjectState {
    projects: ProjectWithAttachments[];
    total: number;
    hydrated: boolean;

    setHydrated: () => void;
    setProjects: (projects: ProjectWithAttachments[], total: number) => void;
    getProjectById: (uuid: string) => ProjectWithAttachments | undefined;
    clearProjects: () => void;
}

export const useProjectStore = create<ProjectState>()(
    persist(
        (set, get) => ({
            projects: [],
            total: 0,
            hydrated: false,

            setHydrated: () => set({ hydrated: true }),

            setProjects: (projects, total) => set({ projects, total }),

            getProjectById: (uuid) =>
                get().projects.find((p) => p.project.uuid === uuid),

            clearProjects: () => set({ projects: [], total: 0 }),
        }),
        {
            name: "project-storage",
            onRehydrateStorage: () => (state) => {
                state?.setHydrated();
            },
        }
    )
);
