"use client"

import { Header } from "@/app/components/header";
import { useActionsStore } from "@/storage/jobsStorage";
import Link from "next/link";
import Image from "next/image";
import { useEffect, useState } from "react";
import { GetProjectSchedule } from "@/app/Api/Api";
import { DataBlock } from "@/models";

export default function EditSchedule() {
    const data = useActionsStore((state) => state.data);
    const addDataBlock = useActionsStore((state) => state.addDataBlock);
    const clearData = useActionsStore((state) => state.clearData)
    const uuid = localStorage.getItem("projectUuid");
    const [message, setMessage] = useState<string | null>(null);
    const [isEmpty, setIsEmpty] = useState(false);

    useEffect(() => {
        async function loadData() {
            try {
                if (uuid) {
                    const { success, message: respMessage, result } = await GetProjectSchedule(uuid);
                    if (success && result && Array.isArray(result.data)) {
                        if (result.data.length > 0) {
                            clearData();
                            result.data.forEach((block: DataBlock) => {
                                addDataBlock({
                                    uuid: block.uuid,
                                    title: block.title,
                                    items: block.items,
                                });
                            });
                        } else {
                            clearData();
                            setIsEmpty(true);
                        }
                    } else if (!success && respMessage === "not found project_schedule") {
                        setIsEmpty(true);
                    } else {
                        setMessage(respMessage || "Ошибка загрузки этапов");
                    }

                } else {
                    setMessage("Ошибка загрузки этапов");
                }
            } catch (error) {
                console.log(error);
                setMessage(`${error}`);
            }
        }

        loadData();
    }, [addDataBlock, clearData, uuid]);

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 flex flex-col items-center gap-4">

                <div className="self-start">
                    <Link
                        href={"/gant"}
                        className="flex flex-row gap-2 items-center"
                    >
                        <Image
                            src={"/backArrow.svg"}
                            alt="Вернуться"
                            height={15}
                            width={30}
                        />
                        <span>Вернуться</span>
                    </Link>
                </div>

                <div className="w-full flex justify-start">
                    <p>График работ</p>
                </div>

                <div className="w-full overflow-x-scroll">
                    <table className="w-full">
                        <thead>
                            <tr>
                                <th>№</th>
                                <th>Этап работы</th>
                                <th>Дата начала</th>
                                <th>Дата окончания</th>
                                <th className="w-[80px]"></th>
                            </tr>
                        </thead>
                        <tbody>
                            {data.length > 0 ? (
                                data.map((block, idx) => (
                                    <tr key={block.uuid}>
                                        <td>{idx + 1}</td>
                                        <td>{block.title}</td>
                                        <td>{block.start_date}</td>
                                        <td>{block.end_date}</td>
                                        <td className="px-4 py-2 text-center">
                                            <div className="flex items-center justify-center gap-3">
                                                <Link href={`/gant/edit/${block.uuid}`}>
                                                    <Image
                                                        alt="Редактирование"
                                                        src="/Tables/edit.svg"
                                                        height={20}
                                                        width={20}
                                                    />
                                                </Link>
                                            </div>
                                        </td>

                                    </tr>
                                ))
                            ) : isEmpty ? (
                                <tr>
                                    <td colSpan={5} className="text-center text-gray-500 py-4">
                                        Таблица пока пустая
                                    </td>
                                </tr>
                            ) : null}
                        </tbody>
                    </table>
                </div>

                <Link href={"/gant/edit/add_subjob"} className="self-center bg-red-700 text-white px-6 py-2 rounded-lg">
                    Добавить этап
                </Link>
                {message && <p className="w-full text-center text-red-600 pt-2">{message}</p>}
            </main>
        </div>
    );
}