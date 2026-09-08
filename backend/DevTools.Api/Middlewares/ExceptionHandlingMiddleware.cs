using DevTools.Domain.Exceptions;
using Microsoft.AspNetCore.Mvc;

namespace DevTools.Api.Middlewares;

public class ExceptionHandlingMiddleware(ILogger<ExceptionHandlingMiddleware> logger) : IMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        try
        {
            await next(context);
        }
        catch (CategoryInUseException ex)
        {
            context.Response.StatusCode = StatusCodes.Status409Conflict;
            await context.Response.WriteAsJsonAsync(new
            {
                message = ex.Message,
                shortcutCount = ex.ShortcutCount,
                commandCount = ex.CommandCount,
            });
        }
        catch (DevToolsDomainException ex)
        {
            var statusCode = ex switch
            {
                InvalidCredentialsException => StatusCodes.Status401Unauthorized,
                UsernameTakenException => StatusCodes.Status409Conflict,
                DuplicateCategoryException => StatusCodes.Status409Conflict,
                DuplicateShortcutTitleException => StatusCodes.Status409Conflict,
                DuplicateCommandTitleException => StatusCodes.Status409Conflict,
                CategoryNotFoundException => StatusCodes.Status404NotFound,
                ShortcutNotFoundException => StatusCodes.Status404NotFound,
                CommandNotFoundException => StatusCodes.Status404NotFound,
                _ => StatusCodes.Status400BadRequest,
            };

            context.Response.StatusCode = statusCode;
            await context.Response.WriteAsJsonAsync(new ProblemDetails
            {
                Status = statusCode,
                Title = ex.GetType().Name,
                Detail = ex.Message,
            });
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception processing {Path}", context.Request.Path);
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            await context.Response.WriteAsJsonAsync(new ProblemDetails
            {
                Status = StatusCodes.Status500InternalServerError,
                Title = "An unexpected error occurred.",
            });
        }
    }
}
