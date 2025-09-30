'use client';

import Image from "next/image";
import Link from "next/link";
import { LogOut } from "@/app/Api/Api";

export function Header() {

    const logoutHandle = () => {
        LogOut();
    }

    return (
        <div className="flex items-center fixed justify-evenly top-0 w-full h-[50px] bg-white border-b-[1px] border-[#D0D0D0] z-50">
            <div className="w-[60%] flex justify-between items-center px-8">
                <div className="flex flex-row items-center gap-4">
                    <Link href={'/list_objects'} className="flex flex-row gap-3 items-center place-content-end">
                        <Image src={'/logo.svg'} alt="Логотип" height={40} width={40}/>
                        <span>ЭСЖ</span>
                    </Link>

                    <Link href={"/list_objects"}>Ваши обьекты</Link>

                    <Link href={"/"}>О нас</Link>
                </div>

                <button onClick={logoutHandle} className="flex place-content-end">Выход</button>
            </div>
        </div>
    )
}