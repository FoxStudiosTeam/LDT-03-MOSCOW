'use client';

import Link from "next/link";

export function Header() {
    return (
        <div className="flex items-center fixed justify-evenly top-0 w-full h-[50px] bg-white border-b-[1px] border-[#D0D0D0] z-50">
            <div className="w-[60%] flex justify-between px-8">
                <Link href={'/'} className="flex place-content-end">Название</Link>

                <Link href={'#'} className="flex place-content-end">Выход</Link>
            </div>
        </div>
    )
}