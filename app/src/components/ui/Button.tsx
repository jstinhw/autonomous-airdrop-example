"use client";
import LoadingAnimation from "../ui/LoadingAnimation";

interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  type?: "button" | "submit" | "reset";
  disabled?: boolean;
  loading?: boolean;
}

export default function Button(props: ButtonProps) {
  const { disabled, onClick, children, loading } = props;

  if (disabled) {
    return (
      <button
        disabled={true}
        className="px-4 py-2 bg-container-main text-darkline font-mono cursor-not-allowed"
      >
        {children}
      </button>
    )
  }
  const emptyFn = () => { };

  if (loading) {
    return (
      <button
        onClick={emptyFn}
        disabled={loading || disabled}
        type={props.type || "button"}
        className="text-highlight text-md font-mono px-4 border-[1px] border-highlight py-2 bg-container-main text-darkline font-mono cursor-not-allowed"
      >
        <div className="flex justify-between items-center gap-2">{"Loading"} <LoadingAnimation /></div>
      </button>
    );
  }
  
  return (
    <button
      onClick={onClick || emptyFn}
      type={props.type || "button"}
      className="text-highlight text-md font-mono border-[1px] border-highlight bg-buttonbg px-4 py-2 hover:bg-buttonbg-hover hover:text-white duration-300 cursor-pointer"
    >
      {children}
    </button>
  )
}