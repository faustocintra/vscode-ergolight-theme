using System;
using System.Collections.Generic;
using System.Linq;

namespace Ergolight.Sample;

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public sealed class AuditAttribute : Attribute { }

public interface IRenderable<T>
{
    string Render(T value);
}

[Audit]
public sealed record Order(int Id, string Status, decimal Amount);

public sealed class OrderRenderer : IRenderable<Order>
{
    public string Render(Order value)
    {
        var tags = new Dictionary<string, object?> { ["paid"] = value.Status == "paid", ["amount"] = value.Amount };
        return string.Join(";", tags.Select(pair => $"{pair.Key}={pair.Value}"));
    }
}

