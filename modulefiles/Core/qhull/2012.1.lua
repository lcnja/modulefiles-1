help(
[[
This module loads QHull 2012.1

The QHull libraries provide functions for computing convex hull, Delaunay
triangulation, Voronoi diagrams, halfspace intersection about a point,
furthest-site Delaunay triangulation, and furthest-site Voronoi diagrams.
See http://www.qhull.org/ for more information.

]])

whatis("Loads QHull libaries for computing convex hull and other operations")
local version = "2012.1"
local base = "/cvmfs/oasis.opensciencegrid.org/osg/modules/qhull/"..version

prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib"))
prepend_path("CPATH",  pathJoin(base, "include"))
prepend_path("LIBRARY_PATH",  pathJoin(base, "lib"))

family('qhull')
