
\d .u

// Creates a dictionary(w) of tables as keys and null values.
init:{w::t!(count t::tables`.)#()}

del:{w[x]_:w[x;;0]?y};.z.pc:{del[;x]each t};

sel:{$[`~y;x;select from x where jobID in y]}

pub:{[t;x]{[t;x;w]if[count x:sel[x]w 1;(neg first w)(`upd;t;x)]}[t;x]each w t}

add:{
  $[(count w x)>i:w[x;;0]?.z.w;.[`.u.w;(x;i;1);union;y];w[x],:enlist(.z.w;y)];
  (x;$[99=type v:value x;sel[v]y;0#v])}

// .u.sub[`;`] returns a list of pairs: (tables;Empty schema)
sub:{if[x~`;:sub[;y]each t];if[not x in t;'x];del[x].z.w;add[x;y]}

// informs all subscribers about 
end:{(neg union/[w[;;0]])@\:(`.u.end;x)}
