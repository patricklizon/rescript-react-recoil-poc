@module external styles: {..} = "./User.module.css"

type t = {
  avatar: string,
  email: string,
  first_name: string,
  id: int,
  last_name: string,
}

module Response = {
  type t<'data>
  @send external json: t<'data> => Promise.t<'data> = "json"
}

module Network = {
  type getUserResponse = {data: t}
  %%private(
    @val @scope("globalThis")
    external fetch: (string, 'params) => Promise.t<Response.t<Js.Nullable.t<getUserResponse>>> =
      "fetch"
  )

  let makeUrl = path => "https://reqres.in/api/users" ++ path

  exception NoValue(string)
  exception WrongId

  let getById = (token: string, userId: int) => {
    let params = {
      "Authorization": `Bearer ${token}`,
    }

    let path = `/${userId->Belt.Int.toString}`

    fetch(path->makeUrl, params)
    ->Promise.then(Response.json)
    ->Promise.then(data => {
      let ret = switch Js.Nullable.toOption(data) {
      | Some(data) => data
      | _ => raise(NoValue("nothing here!"))
      }

      Ok(ret)->Promise.resolve
    })
    ->Promise.catch(err => {
      let msg = switch err {
      | Promise.JsError(err) =>
        switch Js.Exn.message(err) {
        | Some(msg) => msg
        | None => ""
        }
      | _ => "Unexpected error occurred"
      }
      Error(msg)->Promise.resolve
    })
  }
}

module State = {
  let noteAtom = Recoil.asyncAtomFamily({
    key: "noteAtom",
    default: Network.getById("token"),
  })
}

@react.component
let make = (~userId: int) => {
  let userLoadable = Recoil.useRecoilValueLoadable(State.noteAtom(userId))

  switch userLoadable->Recoil.Loadable.getValue {
  | Ok(value) =>
    switch value->Js.Json.stringifyAny {
    | Some(text) => <div className={styles["root"]}> <pre> {text->React.string} </pre> </div>
    | None => {
        Js.log("whoops!")
        React.null
      }
    }
  | Error(msg) => {
      Js.log("wut " ++ msg ++ "?")
      "huh"->React.string
    }
  }
}
