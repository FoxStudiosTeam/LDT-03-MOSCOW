'use client';

import { Header } from "@/app/components/header";

export default function SecondStep() {
    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 flex flex-col items-center gap-4 ">
                <div className="w-full flex flex-row justify-between">
                    <p>Новый объект</p>
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
                    </table>
                </div>

                <button className="self-end bg-red-700 text-white px-6 py-2 rounded-lg">Создать обьект</button>
            </main>
        </div>
    )
}