location ~ /file/route3 {
            default_type text/plain;
        
            access_by_lua_block {
                --ready username and password from headers
                local h_user = ngx.req.get_headers()["username"]
                local h_password = ngx.req.get_headers()["password"]

                local mysql = require "resty.mysql"
                -- local cjson = require "cjson"
                local db, err = mysql:new()
                if not db then
                    ngx.say("failed to instantiate mysql: ", err)
                    return
                end

                db:set_timeout(1000)
                local ok, err, errcode, sqlstate =
                           db:connect{
                              host = "127.0.0.1",
                              port = 3306,
                              database = "ngx_test",
                              user = "root",
                              password = "12345678" }

                if not ok then
                    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
                    return
                end

                -- ngx.say("connected to mysql.")
                local url = string.sub(ngx.var.request_uri,8)
                local quoted_url=ngx.quote_sql_str(url)
                local sql = "select user,password from ngx_test where url="..quoted_url
               
                res, err, errcode, sqlstate = db:query(sql,10)
                if not res then
                    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
                    return
                end

                -- ngx.say(res[1].user)
                -- get user and password in Mysql
                local user = res[1]["user"]
                local password = res[1]["password"]
                
                if (h_user == user and h_password == password) then
                    ngx.say("Authorized request")
                else
                    ngx.exit(403)
                end               
            }
        }
