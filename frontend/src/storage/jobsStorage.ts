import { create } from "zustand";
import { persist } from "zustand/middleware";

export interface Item {
    uuid: string;
    title: string;
    start_date: string;
    end_date: string;
    is_completed: boolean;
    is_deleted: boolean;
    is_draft: boolean;
    measurement: number;
    target_volume: number;
}

export interface DataBlock {
    uuid: string;
    title: string;
    start_date: string;
    end_date: string;
    items?: Item[];
}

interface DataState {
    data: DataBlock[];
    hydrated: boolean;
    setHydrated: () => void;

    addDataBlock: (block: Omit<DataBlock, "start_date" | "end_date">) => void;
    updateDataBlock: (uuid: string, updated: Partial<DataBlock>) => void;
    deleteDataBlock: (uuid: string) => void;
    updateItem: (blockUuid: string, itemUuid: string, updated: Partial<Item>) => void;

    clearData: () => void;
}

function calculateBlockDates(items?: Item[]): { start_date: string; end_date: string } {
    if (!items || items.length === 0) {
        return { start_date: "", end_date: "" };
    }
    const sortedByStart = [...items].sort(
        (a, b) => new Date(a.start_date).getTime() - new Date(b.start_date).getTime()
    );
    const sortedByEnd = [...items].sort(
        (a, b) => new Date(b.end_date).getTime() - new Date(a.end_date).getTime()
    );
    return {
        start_date: sortedByStart[0].start_date,
        end_date: sortedByEnd[0].end_date,
    };
}

export const useActionsStore = create<DataState>()(
    persist(
        (set) => ({
            data: [],
            hydrated: false,

            setHydrated: () => set({ hydrated: true }),

            addDataBlock: (block) =>
                set((state) => {
                    const { start_date, end_date } = calculateBlockDates(block.items);
                    return {
                        data: [
                            ...state.data,
                            { ...block, start_date, end_date, items: block.items ?? [] },
                        ],
                    };
                }),

            updateDataBlock: (uuid, updated) =>
                set((state) => ({
                    data: state.data.map((b) => {
                        if (b.uuid !== uuid) return b;
                        const merged = { ...b, ...updated };
                        const { start_date, end_date } = calculateBlockDates(merged.items);
                        return { ...merged, start_date, end_date, items: merged.items ?? [] };
                    }),
                })),

            deleteDataBlock: (uuid) =>
                set((state) => ({
                    data: state.data.filter((b) => b.uuid !== uuid),
                })),

            updateItem: (blockUuid, itemUuid, updated) =>
                set((state) => ({
                    data: state.data.map((b) => {
                        if (b.uuid !== blockUuid) return b;
                        const newItems = (b.items ?? []).map((i) =>
                            i.uuid === itemUuid ? { ...i, ...updated } : i
                        );
                        const { start_date, end_date } = calculateBlockDates(newItems);
                        return { ...b, items: newItems, start_date, end_date };
                    }),
                })),

            clearData: () => set({ data: [] }),
        }),
        {
            name: "data-storage",
            onRehydrateStorage: () => (state) => {
                state?.setHydrated();
            },
        }
    )
);
