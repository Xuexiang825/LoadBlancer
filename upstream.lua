location = /upstream {
            default_type text/plain;
            content_by_lua_block {
            local concat = table.concat
            local upstream = require "ngx.upstream"
            local get_servers = upstream.get_servers
            local args = ngx.req.get_uri_args()

            if not args["name"] then
                ngx.say("usage:/upstream/name=xx")                      
            else
                local u=args["name"]
                ngx.say("upstream ", u, ":")
                local srvs, err = get_servers(u)
                if not srvs then
                    ngx.say("failed to get servers in upstream ", u)
                else                        
                    for _, srv in ipairs(srvs) do
                        local first = true
                        for k, v in pairs(srv) do
                            if first then
                                first = false
                                ngx.print("    ")
                            else
                                ngx.print(", ")
                            end
                            if type(v) == "table" then
                                ngx.print(k, " = {", concat(v, ", "), "}")
                            else
                                ngx.print(k, " = ", v)
                            end
                        end
                        ngx.print("\n")
                    end
                end
            end

            }
        }
