'use client';

import { Header } from "@/app/components/header";
import React from "react";
import Image from "next/image";
import { useAuthRedirect } from "@/lib/hooks/useAuthRedirect";

type Order = {
    id: number;
    reportDate: string;
    checkDate: string;
    status: string;
};

const ordersData: Order[] = [
    { id: 1, reportDate: "01.01.2025", checkDate: "", status: "Нарушение" },
    { id: 2, reportDate: "01.01.2025", checkDate: "", status: "Исправимо" },
    { id: 3, reportDate: "01.01.2025", checkDate: "", status: "Замечание" },
    { id: 4, reportDate: "01.01.2025", checkDate: "", status: "Нарушение" },
];

export default function Orders() {
    useAuthRedirect();
    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 py-6">
                <table className="w-full border-collapse text-left">
                    <thead>
                    <tr className="bg-gray-100">
                        <th className="border px-4 py-2">Код</th>
                        <th className="border px-4 py-2">Дата отчета</th>
                        <th className="border px-4 py-2">Дата проверки</th>
                        <th className="border px-4 py-2">Статус</th>
                        <th className="border px-4 py-2"></th>
                    </tr>
                    </thead>
                    <tbody>
                    {ordersData.map((order) => (
                        <tr key={order.id} className="hover:bg-gray-50">
                            <td className="border px-4 py-2">{order.id}</td>
                            <td className="border px-4 py-2">{order.reportDate}</td>
                            <td className="border px-4 py-2">{order.checkDate}</td>
                            <td className="border px-4 py-2">{order.status}</td>
                            <td className="border px-4 py-2 text-center">
                                <button className="cursor-pointer">
                                    <Image
                                        src="/Tables/download.svg"
                                        alt="download"
                                        width={20}
                                        height={20}
                                    />
                                </button>
                            </td>
                        </tr>
                    ))}
                    </tbody>
                </table>
            </main>
        </div>
    );
}
