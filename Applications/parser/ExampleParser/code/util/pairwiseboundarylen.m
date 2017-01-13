function pairwise = pairwiseboundarylen(map)

[rows,cols] = size(map);
labels = unique(map);
nlabels = length(labels);
pairwise = zeros(nlabels);

for c = 1 : cols
    for r = 1 : rows
        
      if r ~= rows
        l1 = map(r,c);
        l2 = map(r+1,c);
        if l1 ~= l2
          pairwise(l1, l2) = pairwise(l1, l2) + 1;
          pairwise(l2, l1) = pairwise(l2, l1) + 1;
        end
      end
      
      if c ~= cols
        l1 = map(r,c);
        l2 = map(r,c+1);
        if l1 ~= l2
          pairwise(l1, l2) = pairwise(l1, l2) + 1;
          pairwise(l2, l1) = pairwise(l2, l1) + 1;
        end
      end
      
    end
end