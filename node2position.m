function [pos] = node2position(node,nodes)
%node2position determina la posicion de node en el vector de nodes. Esto es
%útil para plantear el grafo de la red.
a = strcmp(nodes,node);
[b,c] = max(a,[],1);
if b == 0
    pos = [];
else
    pos = c;
end
end

