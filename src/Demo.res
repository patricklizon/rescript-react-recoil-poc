@module external styles: {..} = "./Demo.module.css"

let atom = Recoil.atom({
  key: "atom",
  default: "",
})

@react.component
let make = () => {
  let (atomValue, setAtomValue) = Recoil.useRecoilState(atom)
  let handleMouseEnter = (_: ReactEvent.Mouse.t) => setAtomValue(_ => "xDDDDD")
  let computedText = atomValue->String.length > 0 ? atomValue : "Hello me"

  <div className={styles["root"]} onMouseEnter={handleMouseEnter}>
    {computedText->React.string}
  </div>
}
