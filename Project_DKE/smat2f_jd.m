function s = smat2f_jd(s)



for i = 1:length(s)

    c = s(i);

    if c == 'e'

        s(i) = 'd';

    end

end

