function [qt, np, nrc] = Voperation_OPT(nr, Od, q_inc, kmin, perc, func_Eff)

    % Reshape nr to have size (N, M) where N is the number of rows and M is the number of columns
    nr = reshape(nr, size(nr, 1), size(nr, 3));

    % Multiply each row of nr by the corresponding element of q_inc
    nrc = nr .* q_inc;

    % Calculate qt as the minimum of nrc and Od
    qt = min(nrc, Od);

    % Interpolate values from func_Eff based on qt/Od ratio
    n = interp1(perc, func_Eff, qt ./ Od);

    % Set qt and nrc to zero where qt is less than kmin * Od
    idx = qt < kmin * Od;
    qt(idx) = 0;
    nrc(idx) = 0;

    % Calculate np as the product of n and qt
    np = n .* qt;
end