bring cloud;
bring cognito;
bring dynamodb;


inflight class JsExample {
  pub extern "./handler.ts" static RequestUnicorn(body: str): str;
}


// let WildRydesBucket = new cloud.Bucket({public: true});
let WildRydesApi = new cloud.Api({cors: true});
let WildRydesDynamoDBTable = new dynamodb.Table(
  attributes: [
    {
      name: "RideId",
      type: "S",
    },
  ],
  hashKey: "RideId",
);


let RecordRide = new cloud.Function(inflight (tmp) => {
  let data = Json.parse(tmp!);
  WildRydesDynamoDBTable.put(
    Item: {
        RideId: data["RideId"],
        User: data["username"],
        Unicorn: data["unicorn"],
        UnicornName: data["unicorn"]["Name"],
        RequestTime: data["RequestTime"],
    },
    ReturnValues: "NONE",
  );
}) as "Record Ride";

let RequestUnicorn = new cloud.Function(inflight (body) => {
  let result = JsExample.RequestUnicorn(body!);
  return result;
}) as "Request Unicorn";

WildRydesApi.post("/ride", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
  let body = request.body;
  let data = RequestUnicorn.invoke(body!);
  let _data = Json.parse(data!);
  // log(_data);
  let saveResult = RecordRide.invoke(data);
  return cloud.ApiResponse {
    status: 201,
    body: Json.stringify({
      RideId: _data["RideId"],
      Unicorn: _data["unicorn"],
      UnicornName: _data["unicorn"]["Name"],
      Eta: "30 seconds",
      Rider: _data["username"],
    }),
    headers: {
      "Access-Control-Allow-Origin": "*",
    },
  };
});