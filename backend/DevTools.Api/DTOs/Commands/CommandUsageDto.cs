using DevTools.Domain.Entities;

namespace DevTools.Api.DTOs.Commands;

public record CommandUsageDto(Guid Id, int UsageCount)
{
    public static CommandUsageDto FromDomain(Command command) => new(command.Id, command.UsageCount);
}
