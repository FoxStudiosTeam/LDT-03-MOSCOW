"use client";
import { PunishmentItem } from "@/models";
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

interface PunishmentWithAttachments {
    punishment_item: PunishmentItem;
    attachments: Attachment[];
}

interface ProjectState {
    projects: ProjectWithAttachments[];
    total: number;
    hydrated: boolean;

    punishments: PunishmentWithAttachments[];

    setHydrated: () => void;
    setProjects: (projects: ProjectWithAttachments[], total: number) => void;
    getProjectById: (uuid: string) => ProjectWithAttachments | undefined;
    clearProjects: () => void;

    setPunishmentItem: (
            input:
                | PunishmentWithAttachments
                | PunishmentWithAttachments[]
                | PunishmentItem
                | PunishmentItem[]
            ) => void
    getPunishments: () => PunishmentWithAttachments[];
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

           setPunishmentItem: (
            input:
                | PunishmentWithAttachments
                | PunishmentWithAttachments[]
                | PunishmentItem
                | PunishmentItem[]
            ) =>
            set((state) => {
                const items = Array.isArray(input) ? input : [input];

                const normalized: PunishmentWithAttachments[] = items.map((item) =>
                "attachments" in item
                    ? (item as PunishmentWithAttachments)
                    : { punishment_item: item as PunishmentItem, attachments: [] }
                );

                let newPunishments = [...state.punishments];

                normalized.forEach((item) => {
                const exists = newPunishments.find(
                    (p) => p.punishment_item.uuid === item.punishment_item.uuid
                );
                if (exists) {
                    newPunishments = newPunishments.map((p) =>
                    p.punishment_item.uuid === item.punishment_item.uuid ? item : p
                    );
                } else {
                    newPunishments.push(item);
                }
                });

                return { punishments: newPunishments };
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