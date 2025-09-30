'use client';

import { Header } from "@/app/components/header";
import React, { useEffect, useState } from "react";
import Image from "next/image";
import { GetMaterialsById } from "../Api/Api";

type Material = {
    id: number;
    name: string;
    volume: number;
    deliveryDate: string;
    status: "new" | "researching";
};

const initialMaterials: Material[] = [
    { id: 1, name: "1", volume: 123, deliveryDate: "15.04.2024", status: "new" },
    { id: 2, name: "2", volume: 123, deliveryDate: "15.04.2024", status: "new" },
    { id: 3, name: "3", volume: 123, deliveryDate: "15.04.2024", status: "new" },
    { id: 4, name: "4", volume: 123, deliveryDate: "15.04.2024", status: "new" },
];

export default function Materials() {
    const [materials, setMaterials] = useState<Material[]>(initialMaterials);
    const uuid = localStorage.getItem("projectUuid");
    console.log(uuid)

    useEffect(() => {
        const getMaterials = async () => {
            if (!uuid) return;
            const { successMaterials, messageMaterials, resultMaterials } = await GetMaterialsById(uuid);

            console.log(resultMaterials)
        }

        getMaterials();
    }, [])

    const handleResearchRequest = async (id: number) => {
        try {
            await fetch(`http://localhost:8080/api/materials/${id}/research`, {
                method: "POST",
            });

            setMaterials((prev) =>
                prev.map((m) =>
                    m.id === id ? { ...m, status: "researching" } : m
                )
            );
        } catch (err) {
            console.error("Ошибка при запросе исследования:", err);
        }
    };

    const handleDownload = (id: number, type: "ttn" | "doc") => {
        const url = `http://localhost:8080/api/materials/${id}/download/${type}`;
        window.open(url, "_blank");
    };

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 py-6 flex flex-col items-center gap-4">
                <div className="w-full flex flex-col sm:flex-row justify-between gap-2 sm:gap-0">
                    <p className="font-bold">Материалы</p>
                </div>

                <table className="w-full border-collapse text-left">
                    <thead>
                        <tr className="bg-gray-100">
                            <th className="border px-4 py-2">Название</th>
                            <th className="border px-4 py-2">Объем</th>
                            <th className="border px-4 py-2">Дата поставки</th>
                            <th className="border px-4 py-2">Документы</th>
                            <th className="border px-4 py-2"></th>
                        </tr>
                    </thead>
                    <tbody>
                        {materials.map((m) => (
                            <tr key={m.id} className="hover:bg-gray-50">
                                <td className="border px-4 py-2">{m.name}</td>
                                <td className="border px-4 py-2">{m.volume}</td>
                                <td className="border px-4 py-2">{m.deliveryDate}</td>
                                <td className="border px-4 py-2">
                                    <button
                                        onClick={() => handleDownload(m.id, "ttn")}
                                        className="hover:text-red-600 mr-2"
                                    >
                                        <Image
                                            src="/Tables/docs.svg"
                                            alt="TTN"
                                            width={20}
                                            height={20}
                                        />
                                        <span>ТТН</span>
                                    </button>

                                    <button
                                        onClick={() => handleDownload(m.id, "doc")}
                                        className="hover:text-red-600"
                                    >
                                        <Image
                                            src="/Tables/docs.svg"
                                            alt="Документ"
                                            width={20}
                                            height={20}
                                        />
                                        <span>Документ</span>
                                    </button>
                                </td>

                                <td className="border px-4 py-2 text-right">
                                    {m.status === "new" ? (
                                        <button
                                            onClick={() => handleResearchRequest(m.id)}
                                            className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
                                        >
                                            Запросить исследование
                                        </button>
                                    ) : (
                                        <span className="text-gray-600 font-semibold">Идёт исследование...</span>
                                    )}
                                </td>

                            </tr>
                        ))}
                    </tbody>
                </table>
            </main>
        </div>
    );
}
