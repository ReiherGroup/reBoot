% |----------------------------------------------------------------------------
% |'remove' is a function. It takes an arbitrary matrix ('z') with N rows and 
% |an arbitrary vector ('list'), the entries of which are unique and can range
% |from 1 to N. It returns a matrix that equals z, but with the rows removed
% |defined in list.
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function f = remove(z,list);

  %%% input inspection and processing %%%

  N    = size(z,1);
  L    = length(list);
  list = sort(list,'descend'); 

  if min(size(list)) > 1
    error("second argument must not be a matrix");
  elseif sum(list < 1) || sum(list > N)
    error("some elements in second argument are out of bounds");
  elseif prod(~mod(list,1)) ~= 1
    error("all elements in second argument must be integers");
  elseif sum((repmat(list(:),1,L) == repmat(list(:)',L,1) - eye(L))(:)) > 0
    error("elements in second argument must be unique");
  end

  %%% actual code starts here %%%

  if length(list) == 1
    f = [z(1:list-1,:); z(list+1:end,:)];
  else
    for i = 1:length(list)
      z = remove(z,list(i),:);
    end
    f = z;
  end

end
