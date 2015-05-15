function DrawLinesAtTimes(times, colorstr)

  xlim_vals = get(gca, 'XLim');
  ylim_vals = get(gca, 'YLim');
  
  for i = 1 : length(times)
    plot([times(i); times(i)], [-1e5 1e5], colorstr);
  end

  
  xlim(xlim_vals);
  ylim(ylim_vals);

end