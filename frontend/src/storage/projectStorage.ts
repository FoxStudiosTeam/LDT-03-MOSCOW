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

export interface PunishmentItem {
    uuid: string;
    title: string;
    punishment: string;
    punishment_item_status: number;
    regulation_doc: string;
    punish_datetime: string;
    correction_date_plan: string | null;
    correction_date_info: string | null;
    correction_date_fact: string | null;
    is_suspend: boolean;
    place: string;
    comment: string;
}

interface ProjectState {
    projects: ProjectWithAttachments[];
    total: number;
    hydrated: boolean;

    punishments: PunishmentItem[];

    setHydrated: () => void;
    setProjects: (projects: ProjectWithAttachments[], total: number) => void;
    getProjectById: (uuid: string) => ProjectWithAttachments | undefined;
    clearProjects: () => void;

    setPunishmentItem: (item: PunishmentItem) => void;
    getPunishments: () => PunishmentItem[]; 
    clearPunishments: () => void;
}

export const useProjectStore = create<ProjectState>()(
    persist(
        (set, get) => ({
            projects: [],
            total: 0,
            hydrated: false,

            punishments: [],

            setHydrated: () => set({ hydrated: true }),

            setProjects: (projects, total) => set({ projects, total }),

            getProjectById: (uuid) =>
                get().projects.find((p) => p.project.uuid === uuid),

            clearProjects: () => set({ projects: [], total: 0 }),

            setPunishmentItem: (item) =>
                set((state) => {
                    const exists = state.punishments.find((p) => p.uuid === item.uuid);
                    if (exists) {
                        return {
                            punishments: state.punishments.map((p) =>
                                p.uuid === item.uuid ? item : p
                            ),
                        };
                    }
                    return { punishments: [...state.punishments, item] };
                }),

            getPunishments: () => get().punishments,

            clearPunishments: () => set({ punishments: [] }),
        }),
        {
            name: "project-storage",
            onRehydrateStorage: () => (state) => {
                state?.setHydrated();
            },
        }
    )
);
