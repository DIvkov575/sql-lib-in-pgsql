create type leaky_relu_options as
(
    alpha float
);

create type leaky_relu_weights as
(
    weights float[],
    bias    float,
    alpha   float
);

create or replace function leaky_relu(in x float, in alpha float)
    returns float
    language plpgsql stable
as $$
begin
    IF x > 0 THEN return x;
    ELSEIF x < 0 THEN return x*alpha;
    ELSE return 0;
    END IF;
end;
$$;

create or replace function fit_leaky_relu(in X float[][], in y float[], in opts leaky_relu_options)
    returns leaky_relu_weights
    language plpgsql stable
as $$
declare
    bias float := 0;
    learn_rate float := 0.001;

    n_samples integer;
    n_features integer;

    weights float[];
    pred float[];
    dz float[];
    dw float[];
    db float;
begin
    n_samples = array_length(X, 1);
    n_features = array_length(X, 2);
    weights = array_fill(0.0, ARRAY[n_features]);

    for i in 1..1750 loop
            pred := ARRAY(select leaky_relu(x_0::float, opts.alpha) from unnest(dot(x, weights)) as x_0);
            dz:= ARRAY(select a-b from (select a, row_number() over() as row_num from unnest(pred) as a) t1
                                           join lateral (
                select b, row_number() over() as row_num from unnest(y) as b) t2
                                                on t1.row_num = t2.row_num
                       where t1.row_num = t2.row_num);
            dw := ARRAY(select (1.0 / n_samples) * elem from unnest(dot(t(x), dz)) as elem);
            db := (1 / n_samples) * (select (sum(preds) - sum(ys)) from unnest(pred) as preds, unnest(y) as ys);

            weights := ARRAY(select weight - learn_rate * dws from (select weight, row_number() over() as row_num from unnest(weights) as weight) tb1
                                                                       join (select dws, row_number() over() as row_num from unnest(dw) as dws) tb2
                                                                            on tb1.row_num = tb2.row_num
                             where tb1.row_num = tb2.row_num);
            bias := bias - learn_rate * db;
        end loop;

    return (weights, bias, opts.alpha);
end
$$;


create or replace function predict_leaky_relu(in X float[][], in weights leaky_relu_weights)
    returns float[]
    language plpgsql stable
as $$
declare
begin
    return ARRAY(select leaky_relu(weighed_x + weights.bias , weights.alpha) from unnest(dot(X, weights.weights)) as weighed_x);
end;
$$;
