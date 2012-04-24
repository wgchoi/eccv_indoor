function test_svm_struct_learn
% TEST_SVM_STRUCT_LEARN
%   A demo function for SVM_STRUCT_LEARN(). It shows how to use
%   SVM-struct to learn a standard linear SVM.

  randn('state',0) ;
  rand('state',0) ;

  % ------------------------------------------------------------------
  %                                                      Generate data
  % ------------------------------------------------------------------
  th = pi/3 ;
  c = cos(th) ;
  s = sin(th) ;

  patterns = {} ;
  labels = {} ;
  for i=1:100
    patterns{i} = diag([2 .5]) * randn(2, 1) ;
    labels{i}   = 2*(randn > 0) - 1 ;
    patterns{i}(2) = patterns{i}(2) + labels{i} ;
    patterns{i} = [c -s ; s c] * patterns{i}  ;
  end

  % ------------------------------------------------------------------
  %                                                    Run SVM struct
  % ------------------------------------------------------------------

  parm.patterns = patterns ;
  parm.labels = labels ;
  parm.lossFn = @lossCB ;
  parm.constraintFn  = @constraintCB2;
  parm.featureFn = @featureCB2;
  parm.dimension = 4 ;
  parm.verbose = 0 ;
  model = svm_struct_learn(' -c 100 -o 1 -v 1 ', parm) ;
  w = model.w ;

  % ------------------------------------------------------------------
  %                                                              Plots
  % ------------------------------------------------------------------

  figure() ; clf ; hold on ;
  x = [patterns{:}] ;
  y = [labels{:}] ;
  plot(x(1, y>0), x(2,y>0), 'g.') ;
  plot(x(1, y<0), x(2,y<0), 'r.') ;
  set(line([0 w(1)], [0 w(2)]), 'color', 'y', 'linewidth', 4) ;
  xlim([-3 3]) ;
  ylim([-3 3]) ;
  set(line(1000*[w(2) -w(2)], 1000*[-w(1) w(1)]), ...
      'color', 'y', 'linewidth', 2, 'linestyle', '-') ;
  axis equal ;
  set(gca, 'color', 'b') ;
  w
end

% ------------------------------------------------------------------
%                                               SVM struct callbacks
% ------------------------------------------------------------------

function delta = lossCB(param, y, ybar)
  delta = double(y ~= ybar) ;
  if param.verbose
    fprintf('delta = loss(%3d, %3d) = %f\n', y, ybar, delta) ;
  end
end

function psi = featureCB(param, x, y)
  psi = sparse(y*x/2) ;
  if param.verbose
    fprintf('w = psi([%8.3f,%8.3f], %3d) = [%8.3f, %8.3f]\n', ...
            x, y, full(psi(1)), full(psi(2))) ;
  end
end

function yhat = constraintCB(param, model, x, y)
% slack resaling: argmax_y delta(yi, y) (1 + <psi(x,y), w> - <psi(x,yi), w>)
% margin rescaling: argmax_y delta(yi, y) + <psi(x,y), w>
  if dot(y*x, model.w) > 1, yhat = y ; else yhat = - y ; end
  if param.verbose
    fprintf('yhat = violslack([%8.3f,%8.3f], [%8.3f,%8.3f], %3d) = %3d\n', ...
            model.w, x, y, yhat) ;
  end
end


function psi = featureCB2(param, x, y)

psi = sparse(4, 1);
if(y == 1) % positive
    psi(3:4) = sparse(x);
else       % negative
    psi(1:2) = sparse(x);
end
% psi = sparse(y*x/2) ;
if param.verbose
fprintf('w = psi([%8.3f,%8.3f], %3d) = [%8.3f, %8.3f, %8.3f, %8.3f]\n', ...
        x, y, full(psi)) ;
end
end

function yhat = constraintCB2(param, model, x, y)
% slack resaling: argmax_y delta(yi, y) (1 + <psi(x,y), w> - <psi(x,yi), w>)
% margin rescaling: argmax_y delta(yi, y) + <psi(x,y), w>
v1 = dot(x, model.w(1:2)) + (y ~= -1);
v2 = dot(x, model.w(3:4)) + (y ~= 1);
% psi = featureCB2(param, x, -y) + 1- featureCB2(param, x, y);
if v1 > v2
  yhat = -1; 
else
  yhat = 1; 
end

if (yhat == y)
    tic;
end

if param.verbose
fprintf('yhat = violslack([%8.3f,%8.3f], [%8.3f,%8.3f], %3d) = %3d\n', ...
        model.w, x, y, yhat) ;
end
end