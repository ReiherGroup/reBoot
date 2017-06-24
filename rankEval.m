% |----------------------------------------------------------------------------
% |'rankEval' is a function. It takes a N x dimInput input matrix ('data.x'), 
% |a N x 1 target vector ('data.y'), a N x 1 target-uncertainty vector ('u'), 
% |the polynomial degree ('M'), a 'list' of data-set dimensions, the number of 
% |bootstrap samples ('B'), a structure of optional input ('calOpt'), and a
% |boolean variable for plotting purposes ('calPlot'). It returns a structure
% |containing the RMSE- and RMPV-based rankings of all input-generating methods
% |(dimInput in total) and for each bootstrap sample. A 1 indicates a first
% |place while a 0 indicates a non-first place. If a non-empty resolution
% |('calPlot.resolution') is provided, it can be artificially increased by
% |assigning a positive integer to 'calPlot.increase'. If calPlot = true, two 
% |plots will be generated. The left plot represents the percentage of first 
% |places an input-generating method has reached in the RMSE-based rankings, 
% |whereas the right plot does the same with respect to the RMPV-based ranking.
% |For more details, consult the reBoot manual available at
% |<http://www.reiher.ethz.ch/software/reboot/manual.pdf>.
% |----------------------------------------------------------------------------

function ranking = rankEval(x,y,u,M,list,B,calOpt,calPlot)

  %%% input inspection and processing %%%

  if min(size(x)) < 2
    error("first argument must be a matrix");
  end

  if size(y,2) > 1
    error("second argument must not be a row vector or a matrix");
  elseif size(x,1) ~= size(y,1)
    error("number of rows must be the same in first and second argument");
  end

  if ~isempty(u)
    if size(u,2) > 1
      error("third argument must not be a row vector or a matrix");
    elseif size(x,1) ~= size(u,1)
      if length(u) == 1
        u = repmat(u,length(x),1);
      else
        error("number of rows must be the same in first and third argument");
      end
    elseif ~prod(u > 0)
      error("all elements in third argument must be positive");
    end
  end

  L = length(list);

  if min(size(list)) > 1
    error("fifth argument must not be a matrix");
  elseif sum(list < 1) || prod(~mod(list,1)) ~= 1
    error("all elements in fifth argument must be positive integers");
  elseif sum((repmat(list(:),1,L) == repmat(list(:)',L,1) - eye(L))(:)) > 0
    error("all elements in fifth argument must be unique");
  end

  if ~exist('B') || isempty(B)
    B = 1000;
  elseif length(B) ~= 1
    error("sixth argument must be a scalar");
  elseif (B < 100) || mod(B,1)
    error("sixth argument must be an integer that is 100 or larger");
  end

  if ~exist('calOpt')
    calOpt = struct();
  end

  if ~isfield(calOpt,'resolution')
    calOpt.resolution = [];
  elseif length(calOpt.resolution) > 1
    error("field 'resolution' of seventh argument must be empty or a scalar");
  elseif ~isempty(calOpt.resolution) && mod(calOpt.resolution,1)
    error("field 'resolution' of seventh argument \n\
       (here, non-empty) must be an integer");
  end
  
  if ~isfield(calOpt,'increase')
    calOpt.increase = 0;
  elseif length(calOpt.increase) ~= 1
    error("field 'increase' of seventh argument must be a scalar");
  elseif (calOpt.increase < 0) || mod(calOpt.increase,1)
    error("field 'increase' of seventh argument must be a non-negative integer");
  end

  if ~exist('calPlot')
    calPlot = 0;
  elseif length(calPlot) ~= 1
    error("eigth argument must be a scalar");
  end

  if ~isempty(calOpt.resolution)
    if ~prod(roundResult(u,calOpt.resolution) > 0)
      u(~roundResult(u,calOpt.resolution)) = 10^(-calOpt.resolution);  
    end
    calOpt.resolution += calOpt.increase;
  end

  N = length(x);
  y = roundResult(y,calOpt.resolution);
  u = roundResult(u,calOpt.resolution);
  
  dimInput = size(x,2);

  %%% actual code starts here %%%

  for i = 1:dimInput
    X(:,:,i) = add(x(:,i) - mean(x(:,i)),M);
  end

  dy = 0;
  du = 0;

  for c = 1:L
    for b = 1:B
  
      R = randi([1 N],list(c),1);

      if calOpt.increase
        dy = randi([-5 4],list(c),1) * 10^(-calOpt.resolution);
        du = randi([-5 4],list(c),1) * 10^(-calOpt.resolution);
      end

      if ~isempty(u)
        Y = roundResult(normrnd(y(R) + dy,u(R) + du),calOpt.resolution);
      else
        Y = y(R) + dy;
      end

      for i = 1:dimInput   
        RMSE(i,1) = roundResult(sqrt(mean((Y - X(R,:,i) * ...
	                        (X(R,:,i) \ Y)).^2)),calOpt.resolution);
        RMPV(i,1) = roundResult(bayesCal(x(R,i),Y,[],M,1,calOpt).RMPV, ...
	                        calOpt.resolution);
      end

      ranking.RMSE(:,b,c) = (min(RMSE) == RMSE);
      ranking.RMPV(:,b,c) = (min(RMPV) == RMPV);

      printf(" %d / %d bootstrap samples \r",b + (c - 1) * B,B * L);
      fflush(stdout);

    end
  end

  disp("");

  %%% plotting session %%%

  if calPlot

    close(figure(2));
    close(figure(3));

    for c = 1:L

      figure(2)
      subplot(round(sqrt(L)),ceil(sqrt(L)),c); hold
        barh(mean(ranking.RMSE(:,:,c),2) * 100,1,'facecolor','yellow');
        axis([0,100,0.5,dimInput + 0.5],'square');
        set(gca,'tickdir','out');
        title("RMSE-based ranking");
        xlabel("% first places");
        ylabel("input ID");
      
      figure(3)
      subplot(round(sqrt(L)),ceil(sqrt(L)),c); hold
        barh(mean(ranking.RMPV(:,:,c),2) * 100,1,'facecolor','yellow');
        axis([0,100,0.5,dimInput + 0.5],'square');
        set(gca,'tickdir','out');
        title("RMPV-based ranking");
        xlabel("% first places");
        ylabel("input ID");

    end

  end

end
