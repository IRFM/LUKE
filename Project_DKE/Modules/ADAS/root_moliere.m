function y = root_moliere(R)
    %
    jmax = length(R)/2;
    y = zeros(size(R));
    %
    if jmax == 3
        %
        Y = [R(1);R(2);R(3)];
        A1 = [R(2),-R(3),R(4);R(3),-R(4),R(5);R(4),-R(5),R(6)];
        X = A1\Y;%find 3rd degree polynomial equation
        %
        y(jmax+1:end) = roots([1 -X(1) X(2) -X(3)]);%solve 3rd degree polynomial equation
        %
        A2 = [y(4),y(5),y(6);1,1,1;1/y(4),1/y(5),1/y(6)];
        y(1:jmax) = (A2\Y)';
        %
        if real(y(4)) > 0 && real(y(5)) > 0  && real(y(6)) > 0 && imag(y(4)) == 0 && imag(y(5)) == 0 && imag(y(6)) == 0
            %
            return
            %
        else
            %
            R = [R(1),R(2),R(3),R(4)];
            jmax = length(R)/2;
            y = zeros(size(R));
            %
        end
        %

    end
    %
    if jmax == 2
        %
        y(jmax+1:end) = roots([R(4) - R(3)^2,R(3)-R(1)*R(4),R(1)*R(3)-1]);%solve 2nd degree polynomial equation
        y(1:jmax) = [(R(1) - y(4))/(y(3) - y(4)),1 - (R(1) - y(4))/(y(3) - y(4))];
        %
        if real(y(3)) > 0 && real(y(4)) > 0 && imag(y(3)) == 0 && imag(y(4)) == 0
            %
            return
            %
        else
            %
            R = [R(1),R(2)];
            jmax = length(R)/2;
            y = zeros(size(R));
            %
        end
        %
    end
    %
    if jmax == 1
        %
        y(1) = R(2);
        y(2) = R(1);
        %
    end
    %
end