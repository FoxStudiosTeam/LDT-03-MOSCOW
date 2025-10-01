"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

export function useAuthRedirect() {
  const router = useRouter();
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("access_token");

    if (!token) {
      router.replace("/sign_in");
    } else {
      setIsReady(true);
    }
  }, [router]);

  return isReady;
}