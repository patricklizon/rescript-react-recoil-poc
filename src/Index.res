exception NoRoot
exception WrongUserId(string)

module Router = {
  @react.component
  let make = () => {
    let url = RescriptReactRouter.useUrl()
    let (formField, setFormField) = React.useState(_ => "")

    switch url.path {
    | list{"user", id} =>
      try {
        let maybeId = switch id->Belt.Int.fromString {
        | Some(i) => i
        | None =>
          raise(
            WrongUserId("Id of \"" ++ id ++ "\" is not correct!" ++ "\n" ++ "try Integer instead"),
          )
        }

        <React.Suspense fallback={"Loading..."->React.string}>
          <User userId={maybeId} />
        </React.Suspense>
      } catch {
      | WrongUserId(msg) => msg->React.string
      }
    | list{} => {
        let handleSubmit = (e: ReactEvent.Form.t) => {
          e->ReactEvent.Form.preventDefault
          RescriptReactRouter.push(`/user/${formField}`)
          Js.log(formField)
        }

        let handleChange = (e: ReactEvent.Form.t) => {
          let value = ReactEvent.Form.currentTarget(e)["value"]
          setFormField(value)
        }

        <form onSubmit={handleSubmit}>
          <input name="userId" onChange={handleChange} placeholder="enter user id" />
        </form>
      }
    | _ => "Not found!"->React.string
    }
  }
}

switch ReactDOM.querySelector("#root") {
| Some(root) =>
  ReactDOM.render(<main> <Recoil.RecoilRoot> <Router /> </Recoil.RecoilRoot> </main>, root)
| None => raise(NoRoot)
}
