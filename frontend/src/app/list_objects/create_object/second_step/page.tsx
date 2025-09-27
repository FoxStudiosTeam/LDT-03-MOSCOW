'use client';

import { Header } from "@/app/components/header";
import { useActionsStore } from "@/storage/jobsStorage";
import Link from "next/link";
import Image from "next/image";
import {useEffect, useState} from "react";
import {GetProjectSchedule} from "@/app/Api/Api";
import {DataBlock} from "@/models";

export default function SecondStep() {
    const data = useActionsStore((state) => state.data);
    const deleteDataBlock = useActionsStore((state) => state.deleteDataBlock);
    const addDataBlock = useActionsStore((state) => state.addDataBlock);
    const uuid = localStorage.getItem("projectUuid");
    const [message, setMessage] = useState<string | null>(null);
    const [isEmpty, setIsEmpty] = useState(false);

    useEffect(() => {
        async function loadData() {
            try {
                if (uuid){
                    const {success, message: respMessage, result} = await GetProjectSchedule(uuid);
                    if (success && result && result.data.length > 0) {
                        result.data.forEach((block: DataBlock) => {
                            addDataBlock({
                                uuid: block.uuid,
                                title: block.title,
                                items: block.items,
                            });
                        });
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
    }, [addDataBlock, uuid]);

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 flex flex-col items-center gap-4">
                <div className="w-full flex flex-row justify-between">
                    <p className="font-bold">Новый объект</p>
                    <p>Этап 2 из 2</p>
                </div>

                <div className="w-full">
                    <div className="flex flex-row justify-between items-center">
                        <p>График работ</p>
                        <Link href={"/list_objects/create_object/second_step/add_subjobs/"} className="bg-red-700 text-white px-6 py-2 rounded-lg">
                            Добавить этап работы
                        </Link>
                    </div>
                </div>

                <div className="w-full">
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
                                    <td className="flex flex-row gap-3">
                                        <Link
                                            href={`/list_objects/create_object/second_step/edit/${block.uuid}`}
                                        >
                                            <Image
                                                alt="Редактирование"
                                                src={"/Tables/edit.svg"}
                                                height={15}
                                                width={15}
                                            />
                                        </Link>
                                        <button onClick={() => deleteDataBlock(block.uuid)}>
                                            <Image
                                                alt="Удаление"
                                                src={"/Tables/delete.svg"}
                                                height={15}
                                                width={15}
                                            />
                                        </button>
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

                <button className="self-end bg-red-700 text-white px-6 py-2 rounded-lg">
                    Создать объект
                </button>
                {message && <p className="w-full text-center text-red-600 pt-2">{message}</p>}
            </main>
        </div>
    );
}
