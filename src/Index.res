exception NoRoot

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<Recoil.RecoilRoot> <Demo /> </Recoil.RecoilRoot>, root)
| None => raise(NoRoot)
}
