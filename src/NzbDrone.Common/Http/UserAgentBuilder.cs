using NzbDrone.Common.EnvironmentInfo;

namespace NzbDrone.Common.Http
{
    public interface IUserAgentBuilder
    {
        string GetUserAgent(bool simplified = false);
    }

    public class UserAgentBuilder : IUserAgentBuilder
    {
        private readonly string _userAgentSimplified;
        private readonly string _userAgent;
        private static Random random = new Random();

        public string GetUserAgent(bool simplified)
        {
            if (simplified)
            {
                return _userAgentSimplified;
            }

            return _userAgent;
        }

        public UserAgentBuilder(IOsInfo osInfo)
        {
            var osName = OsInfo.Os.ToString();

            if (!string.IsNullOrWhiteSpace(osInfo.Name))
            {
                osName = osInfo.Name.ToLower();
            }

            var osVersion = osInfo.Version?.ToLower();

            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            string AppName = new string(Enumerable.Repeat(chars, 8).Select(s => s[random.Next(s.Length)]).ToArray());

            _userAgent = $"{AppName}/{BuildInfo.Version} ({osName} {osVersion})";
            _userAgentSimplified = $"{AppName}/{BuildInfo.Version.ToString(2)}";
        }
    }
}
