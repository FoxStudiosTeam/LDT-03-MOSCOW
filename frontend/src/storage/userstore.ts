import { create } from "zustand";
import { persist } from "zustand/middleware";

type UserData = {
    role: string;
    org: string;
    uuid?: string; //возможно уйдет
} | null;

type UserState = {
    userData: UserData;
    hydrated: boolean;
    setUserData: (data: UserData) => void;
    setHydrated: () => void;
};

export const useUserStore = create<UserState>()(
    persist(
        (set) => ({
            userData: null,
            hydrated: false,
            setUserData: (data) => set({ userData: data }),
            setHydrated: () => set({ hydrated: true }),
        }),
        {
            name: "userdata-storage",
            onRehydrateStorage: () => (state) => {
                state?.setHydrated?.();
            },
        }
    )
);