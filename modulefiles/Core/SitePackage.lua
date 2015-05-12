require("strict")
local hook = require("Hook")
local http = require("socket.http")
http.TIMEOUT = 30

function url_quote(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str    
end


function get_project(str)
    local project = nil
    if (str) then
        for match in string.gmatch(str, "ProjectName%s+=%s+\"(.-)\"") do
            project = match
        end
    end
    return project
end

function get_username(str)
    local username = nil
    if (str) then
        for match in string.gmatch(str, "Owner%s+=%s+\"(.-)@.-\"") do
            username = match
        end
    end
    return username
end

function get_site(str)
    local site = nil
    if (str) then
        for match in string.gmatch(str, "JOBGLIDEIN_ResourceName%s+=%s+\"(.-)\"") do
            site = match
        end
    end
    return site
end

-- By using the hook.register function, this function "load_hook" is called
-- ever time a module is loaded with the file name and the module name.

function load_hook(t)
   -- the arg t is a table:
   -- t.modFullName: the module full name: (i.e: gcc/4.7.2)
   -- t.fn: The file name: (i.e /apps/modulefiles/Core/gcc/4.7.2.lua)

   -- Your site can use this any way that suits. Here are some possibilities:
   -- a) Write this information into a file in your users directory (say ~/.lmod.d/.save).
   -- Then once a month collect this data.
   -- b) have this function call syslogd to register that this module was loaded by this
   -- user
   -- c) Write the same information directly to some database.

   -- This is the directory in which this script resides, and it pulls the rest
   -- of the required scripts and config from this same directory. (It would
   -- be better to compute this, but my lua skills are lacking.)
   local dirname = os.getenv("LMOD_PACKAGE_PATH")

   local username = os.getenv("OSGVO_SUBMITTER")
   if username == nil then
      username = 'UNAVAILABLE'
   end
   local project = os.getenv("OSGVO_PROJECT_NAME")
   if project == nil then
      project = 'UNAVAILABLE'
   end
   local site = os.getenv("OSG_SITE_NAME")
   if site == nil then
      site = 'UNAVAILABLE'
   end
   local fhandle = io.popen('/bin/hostname -f', 'r')
   local host = fhandle:read()
   fhandle:close()
   if host == nil then
      host = 'UNAVAILABLE'
   end

   local condor_classad_file = os.getenv('_CONDOR_JOB_AD')
   if condor_classad_file ~= nil then
       local f = io.open(condor_classad_file, 'r')
       local classads = f:read("*all")
       if classads ~= nil then
           username = get_username(classads)
           if site == 'UNAVAILABLE' then
               site = get_site(classads)
           end
           if project == 'UNAVAILABLE' then
               project = get_project(classads)
           end
       end
   end
   if dirname ~= '' and username ~= '' and t.modFullName ~= '' then
      -- We don't want failure to log to block jobs or give errors. Make an
      -- effort to log things, but ignore anything that goes wrong. Also do
      -- not wait on the subprocess.
      local uri = 'http://modules.ci-connect.net/register_module.wsgi?'
      uri = uri .. 'user=' .. url_quote(username)
      uri = uri .. '&project=' .. url_quote(project)
      uri = uri .. '&module=' .. url_quote(t.modFullName)
      uri = uri .. '&site=' .. url_quote(site)
      uri = uri .. '&host=' .. url_quote(host)
      http.request(uri)
   end
end


hook.register("load",load_hook)
