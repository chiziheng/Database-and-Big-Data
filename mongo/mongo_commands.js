use admin
db.createUser({
      user: "Mongodbadmin",
      pwd: "&V]xM);}^$ts&9U-hC[C",
      roles: [
                { role: "userAdminAnyDatabase", db: "admin" },
                { role: "readWriteAnyDatabase", db: "admin" },
                { role: "dbAdminAnyDatabase",   db: "admin" }
             ]
  });
use kindle_metadata
db.createCollection("kindle_metadata")
db.createUser({user:'test_user',pwd:'test_user',roles:[{role:'readWrite',db:'kindle_metadata'},{role:'readWrite',db:'web_logs'}]})
use web_logs
db.createCollection("web_logs")
db.createUser({user:'test_user',pwd:'test_user',roles:[{role:'readWrite',db:'kindle_metadata'},{role:'readWrite',db:'web_logs'}]})
