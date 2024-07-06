bring cloud;
bring cognito;
bring dynamodb;

inflight class JsExample {
  pub extern "./handler.ts" static RequestUnicorn(body: str, username: str): str;
}

let WildRydesApi = new cloud.Api({cors: true, corsOptions: {allowOrigin: "*"}});
let WildRydesDynamoDBTable = new dynamodb.Table(
  attributes: [
    {
      name: "RideId",
      type: "S",
    },
  ],
  hashKey: "RideId",
);
let WildRydesCognito = new cognito.Cognito(WildRydesApi);


let RequestUnicorn = new cloud.Function(inflight (body) => {
  let result = JsExample.RequestUnicorn(body!, "WildRydesCognito.clientId");
  let data = Json.parse(result);
  log(data);
  WildRydesDynamoDBTable.put(
    Item: {
        RideId: data["RideId"],
        User: data["Rider"],
        Unicorn: data["unicorn"],
        UnicornName: data["unicorn"]["Name"],
        RequestTime: data["RequestTime"],
    },
    ReturnValues: "NONE",
  );
  return result;
}) as "Request Unicorn";

WildRydesApi.post("/test", inflight (request) => {
  let body = Json.parse(request.body!);
  let user = str.fromJson(body["username"]);
  let tmp = "hello {user} !! it's your 22th birthday !!!!!";
  return cloud.ApiResponse {
      status: 200,
      // headers: {"Content-Type": "application/json"},
      body: tmp
  };
});

WildRydesApi.post("/ride", inflight (request) => {
  let body = request.body;
  let data = RequestUnicorn.invoke(body!);
  let _data = Json.parse(data!);
  return cloud.ApiResponse {
    status: 201,
    body: Json.stringify({
      RideId: _data["RideId"],
      Unicorn: _data["unicorn"],
      UnicornName: _data["unicorn"]["Name"],
      Eta: "30 seconds",
      Rider: _data["Rider"],
    }),
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Content-Type" : "application/json"
    },
  };
});

// protected endpoints

WildRydesCognito.post("/ride");