"use client";

import { GetPunishmentsById } from "@/app/Api/Api";
import { Header } from "@/app/components/header";
import { Punishments } from "@/models";
import { useProjectStore } from "@/storage/projectStorage";
import Image from "next/image";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useEffect, useState } from "react";


export default function PunishmentPage() {
    const params = useParams();
    const id = Array.isArray(params.id) ? params.id[0] : params.id;
    const [punishments, setPunishments] = useState<Punishments[]>([]);
    const PunishmentItem = useProjectStore((state) => state.getPunishments());

    console.log('PunishmentItem', PunishmentItem)

    useEffect(() => {
        const getPunishments = async () => {
            if (!id) return;
            const result = await GetPunishmentsById(id);

            if (result) {
                setPunishments(result.resultPunishment)
            }

        }
        getPunishments()
    }, [id])

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 py-6 flex flex-col items-center gap-4">
                <div className="w-full flex flex-col sm:flex-row justify-between gap-2 sm:gap-0">
                    <p className="font-bold">Предписания</p>
                </div>

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
                        {PunishmentItem.map((punishment, punishmentIdx) => (
                            <Link key={punishmentIdx} href={'#'}>
                                <tr className="hover:bg-gray-50">

                                    <td className="border px-4 py-2">{punishmentIdx}</td>
                                    {/* <td className="border px-4 py-2">{punishment.}</td> */}
                                    <td className="border px-4 py-2">{punishment.punish_datetime}</td>
                                    <td className="border px-4 py-2">{ }</td>
                                    <td className="border px-4 py-2">{punishment.place}</td>

                                    <td className="border px-4 py-2 text-right">
                                        {/* {m.status === "new" ? (
                                        <button
                                            onClick={() => handleResearchRequest(m.id)}
                                            className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
                                        >
                                            Запросить исследование
                                        </button>
                                    ) : (
                                        <span className="text-gray-600 font-semibold">Идёт исследование...</span>
                                    )} */}
                                    </td>
                                </tr>
                            </Link>
                        ))}
                    </tbody>
                </table>
            </main>
        </div>
    )
}