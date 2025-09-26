'use client';

import { Header } from "@/app/components/header";
import { useActionsStore } from "@/storage/jobsStorage";
import Link from "next/link";
import Image from "next/image";

export default function SecondStep() {

    const jobsData = useActionsStore((state) => state.jobs);
    const deleteJob = useActionsStore((state) => state.deleteJob)

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 flex flex-col items-center gap-4 ">
                <div className="w-full flex flex-row justify-between">
                    <p className="font-bold">Новый объект</p>
                    <p>Этап 2 из 2</p>
                </div>

                <div className="w-full">
                    <div className="flex flex-row justify-between items-center">
                        <p>График работ</p>
                        <button className="bg-red-700 text-white px-6 py-2 rounded-lg">Добавить этап работы</button>
                    </div>

                </div>

                <div className="w-full">
                    <table className="w-full">
                        <thead>
                            <tr>
                                <th>№</th>
                                <th>Этап работы</th>
                                <th>Дата начала</th>
                                <th className="">Дата окончание</th>
                                <th className="w-[80px]"></th>
                            </tr>
                        </thead>
                        <tbody>
                            {jobsData.map((item, itemIdx) => (
                                <tr key={itemIdx}>
                                    <td>{itemIdx + 1}</td>
                                    <td>{item.title}</td>
                                    <td>{item.startDate}</td>
                                    <td>{item.endDate}</td>
                                    <td className="flex flex-row gap-3">
                                        <Link href={`/list_objects/create_object/second_step/edit/${itemIdx}`}><Image alt="Редактирование" src={'/Tables/edit.svg'} height={15} width={15}></Image></Link>
                                        <button onClick={() => deleteJob(item.id)}><Image alt="Редактирование" src={'/Tables/delete.svg'} height={15} width={15}></Image></button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                <button className="self-end bg-red-700 text-white px-6 py-2 rounded-lg">Создать обьект</button>
            </main >
        </div >
    )
}