local Functions = {}

-- Add all the functions from the original script here
Functions.ShowNotification = function(String)
    if getgenv().Fluent then
        getgenv().Fluent:Notify({
            Title = "Lucid Hub",
            Content = String,
            Duration = 5
        })
    end
end

Functions.autoCast = function()
    -- Copy the autoCast function from the original script
end

Functions.autoShake = function()
    -- Copy the autoShake function from the original script
end

Functions.autoReel = function()
    -- Copy the autoReel function from the original script
end

-- Add other functions as needed

return Functions