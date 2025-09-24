'use client';

import { Header } from "@/app/components/header";

interface SubObjects {
    name: string;
    volume: number;
    unitOfMeasurement: string;
    startDate: string;
    endDate: string;
}

const objects: SubObjects[] = [
    {
        name: 'Замена дорожного бортового камня в рамках благоустройства территории',
        volume: 666,
        unitOfMeasurement: "Погонный метр",
        startDate: '25.08.2024',
        endDate: '25.08.2024',
    },
    {
        name: 'Замена дорожного бортового камня в рамках благоустройства территории',
        volume: 666,
        unitOfMeasurement: "Погонный метр",
        startDate: '25.08.2024',
        endDate: '25.08.2024',
    },
    {
        name: 'Замена дорожного бортового камня в рамках благоустройства территории',
        volume: 666,
        unitOfMeasurement: "Погонный метр",
        startDate: '25.08.2024',
        endDate: '25.08.2024',
    },
    {
        name: 'Замена дорожного бортового камня в рамках благоустройства территории',
        volume: 666,
        unitOfMeasurement: "Погонный метр",
        startDate: '25.08.2024',
        endDate: '25.08.2024',
    },
    {
        name: 'Замена дорожного бортового камня в рамках благоустройства территории',
        volume: 666,
        unitOfMeasurement: "Погонный метр",
        startDate: '25.08.2024',
        endDate: '25.08.2024',
    },
]

export default function AddSubjobs() {
    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="min-h-[calc(100vh-50px)] w-[80%] bg-white px-[10%] flex flex-col items-center gap-4 ">
                <div className="w-full">
                    <p>Добавить этап работы</p>
                </div>

                <div className="w-full flex flex-col gap-4">
                    <div className="flex flex-row justify-between gap-14">
                        <div className="w-full flex flex-col">
                            <label>Этап работы</label>
                            <select></select>
                        </div>

                        <div className="w-full flex flex-col">
                            <label>КПГЗ</label>
                            <input type="text" className="w-full h-[30px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500" />
                        </div>
                    </div>

                    <div className="flex flex-row justify-between gap-14">
                        <div className="w-full flex flex-col">
                            <label>КПГЗ</label>
                            <input type="date" className="w-full h-[30px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500" />
                        </div>
                        <div className="w-full flex flex-col">
                            <label>КПГЗ</label>
                            <input type="date" className="w-full h-[30px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500" />
                        </div>
                    </div>
                </div>

                <div className="w-full">
                    <table className="w-full">
                        <thead>
                            <tr>
                                <th>Наименование работы</th>
                                <th>Объем</th>
                                <th>Единицы измерений</th>
                                <th>Дата начала</th>
                                <th>Дата окончание</th>
                                <th className="w-[80px]"></th>
                            </tr>
                        </thead>
                        <tbody>
                            {objects.map((item, itemIdx) => (
                                <tr key={itemIdx}>
                                    <td>{item.name}</td>
                                    <td>{item.volume}</td>
                                    <td>{item.unitOfMeasurement}</td>
                                    <td>{item.startDate}</td>
                                    <td>{item.endDate}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                <button className="bg-red-700 text-white px-6 py-2 rounded-lg ">Добавить строку</button>
                <button className="self-end bg-red-700 text-white px-6 py-2 rounded-lg ">Сохранить</button>
            </main>
        </div>
    )
}